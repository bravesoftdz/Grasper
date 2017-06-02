<?php

namespace PIA\appBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * JobNodes
 */
class JobNodes
{
    /**
     * @var integer
     */
    private $id;

    /**
     * @var string
     */
    private $tag;

    /**
     * @var integer
     */
    private $index;

    /**
     * @var string
     */
    private $tagId;

    /**
     * @var string
     */
    private $class;

    /**
     * @var string
     */
    private $name;

    /**
     * @var \PIA\appBundle\Entity\JobRules
     */
    private $jobRule;


    /**
     * Get id
     *
     * @return integer 
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Set tag
     *
     * @param string $tag
     * @return JobNodes
     */
    public function setTag($tag)
    {
        $this->tag = $tag;

        return $this;
    }

    /**
     * Get tag
     *
     * @return string 
     */
    public function getTag()
    {
        return $this->tag;
    }

    /**
     * Set index
     *
     * @param integer $index
     * @return JobNodes
     */
    public function setIndex($index)
    {
        $this->index = $index;

        return $this;
    }

    /**
     * Get index
     *
     * @return integer 
     */
    public function getIndex()
    {
        return $this->index;
    }

    /**
     * Set tagId
     *
     * @param string $tagId
     * @return JobNodes
     */
    public function setTagId($tagId)
    {
        $this->tagId = $tagId;

        return $this;
    }

    /**
     * Get tagId
     *
     * @return string 
     */
    public function getTagId()
    {
        return $this->tagId;
    }

    /**
     * Set class
     *
     * @param string $class
     * @return JobNodes
     */
    public function setClass($class)
    {
        $this->class = $class;

        return $this;
    }

    /**
     * Get class
     *
     * @return string 
     */
    public function getClass()
    {
        return $this->class;
    }

    /**
     * Set name
     *
     * @param string $name
     * @return JobNodes
     */
    public function setName($name)
    {
        $this->name = $name;

        return $this;
    }

    /**
     * Get name
     *
     * @return string 
     */
    public function getName()
    {
        return $this->name;
    }

    /**
     * Set jobRule
     *
     * @param \PIA\appBundle\Entity\JobRules $jobRule
     * @return JobNodes
     */
    public function setJobRule(\PIA\appBundle\Entity\JobRules $jobRule = null)
    {
        $this->jobRule = $jobRule;

        return $this;
    }

    /**
     * Get jobRule
     *
     * @return \PIA\appBundle\Entity\JobRules 
     */
    public function getJobRule()
    {
        return $this->jobRule;
    }
}
